"""empty message

Revision ID: 83a68b245bd7
Revises: 24848ac56fff
Create Date: 2020-08-16 23:18:09.388585

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '83a68b245bd7'
down_revision = '24848ac56fff'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('blog_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('carousel_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('comment', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('reshare_with_comment', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('shareable_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    with op.batch_alter_table('timeline_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('timeline_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('shareable_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('reshare_with_comment', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('comment', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('carousel_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    with op.batch_alter_table('blog_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.BOOLEAN(), nullable=True))

    # ### end Alembic commands ###

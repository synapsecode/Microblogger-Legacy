"""empty message

Revision ID: 50ac3574609c
Revises: 83a68b245bd7
Create Date: 2020-08-16 23:18:53.743441

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '50ac3574609c'
down_revision = '83a68b245bd7'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('edited', sa.Boolean(), nullable=True))

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.drop_column('edited')

    # ### end Alembic commands ###

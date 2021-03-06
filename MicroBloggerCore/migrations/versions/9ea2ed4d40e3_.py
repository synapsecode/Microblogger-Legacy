"""empty message

Revision ID: 9ea2ed4d40e3
Revises: bc0112af1115
Create Date: 2020-08-16 23:20:25.640235

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9ea2ed4d40e3'
down_revision = 'bc0112af1115'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.drop_column('edited')

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('edited', sa.BOOLEAN(), nullable=True))

    # ### end Alembic commands ###
